require 'rails_helper'

feature 'Poll Questions' do

  scenario 'Lists questions from proposals before regular questions' do
    poll = create(:poll)
    normal_question = create(:poll_question, poll: poll)
    proposal_question = create(:poll_question, proposal: create(:proposal), poll: poll)

    visit poll_path(poll)

    expect(proposal_question.title).to appear_before(normal_question.title)
  end

  context 'Answering' do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, geozone_restricted: true, geozone_ids: [geozone.id]) }
    scenario 'Non-logged in users' do
      question = create(:poll_question, valid_answers: 'Han Solo, Chewbacca')

      visit question_path(question)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must Sign in or Sign up to participate')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 1 users' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')

      login_as(create(:user, geozone: geozone))
      visit question_path(question)

      expect(page).to have_content('Han Solo')
      expect(page).to have_content('Chewbacca')
      expect(page).to have_content('You must verify your account in order to answer')

      expect(page).to_not have_link('Han Solo')
      expect(page).to_not have_link('Chewbacca')
    end

    scenario 'Level 2 users in an poll question for a geozone which is not theirs' do

      other_poll = create(:poll, geozone_restricted: true, geozone_ids: [create(:geozone).id])
      question = create(:poll_question, poll: other_poll, valid_answers: 'Vader, Palpatine')

      login_as(create(:user, :level_two, geozone: geozone))
      visit question_path(question)

      expect(page).to have_content('Vader')
      expect(page).to have_content('Palpatine')
      expect(page).to_not have_link('Vader')
      expect(page).to_not have_link('Palpatine')
    end

    scenario 'Level 2 users who can answer' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')

      login_as(create(:user, :level_two, geozone: geozone))
      visit question_path(question)

      expect(page).to have_link('Answer this question')
    end

    scenario 'Level 2 users who have already answered' do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')

      user = create(:user, :level_two, geozone: geozone)
      create(:poll_answer, question: question, author: user, answer: 'Chewbacca')

      login_as user
      visit question_path(question)

      expect(page).to have_link('Answer this question')
    end

    scenario 'Level 2 users answering', :js do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit question_path(question)

      expect(page).to have_link('Answer this question')
    end

    scenario 'Records participarion', :js do
      question = create(:poll_question, poll: poll, valid_answers: 'Han Solo, Chewbacca')
      user = create(:user, :level_two, geozone: geozone)

      login_as user
      visit question_path(question)

      click_link 'Answer this question'
      click_link 'Han Solo'

      expect(page).to_not have_link('Han Solo')

      answer = Poll::Answer.by_question(question.id).by_author(user.id).first
      expect(answer.voter.document_number).to eq(user.document_number)
      expect(answer.voter.poll_id).to eq(poll.id)
    end

  end
end
