require 'rails_helper'

feature 'Tracking' do

  context 'User data' do

    context 'User ID' do

      scenario 'Anonymous' do
        visit "/"

        expect(page).to_not have_css("span[data-track-user-id]")
      end

      scenario 'Logged in' do
        user = create(:user)

        login_as(user)
        visit "/"

        expect(page).to have_css("span[data-track-user-id='#{user.id}']")
      end

    end

    context 'Verification level' do

      scenario 'Anonymous' do
        visit "/"

        expect(page).to_not have_css("span[data-track-verification-level]")
      end

      scenario 'Level 1' do
        login_as(create(:user))
        visit "/"

        expect(page).to have_css("span[data-track-verification-level='Nivel 1']")
      end

      scenario 'Level 2' do
        login_as(create(:user, :level_two))
        visit "/"

        expect(page).to have_css("span[data-track-verification-level='Nivel 2']")
      end

      scenario 'Level 3' do
        login_as(create(:user, :level_three))
        visit "/"

        expect(page).to have_css("span[data-track-verification-level='Nivel 3']")
      end

    end

    context 'Demographics' do

      scenario 'Age' do
        user = create(:user, date_of_birth: 18.years.ago)

        login_as(user)
        visit "/"

        expect(page).to have_css("span[data-track-age='18']")
      end

      scenario 'Gender' do
        male   = create(:user, gender: 'male')
        female = create(:user, gender: 'female')

        login_as(male)
        visit "/"

        expect(page).to have_css("span[data-track-gender='Hombre']")

        login_as(female)
        visit "/"

        expect(page).to have_css("span[data-track-gender='Mujer']")
      end

      scenario 'District' do
        new_york = create(:geozone, name: "New York")
        user = create(:user, geozone: new_york)

        login_as(user)
        visit "/"

        expect(page).to have_css("span[data-track-district='New York']")
      end
    end

  end

  context 'Events' do

    scenario 'Login' do
      user = create(:user)
      login_through_form_as(user)

      expect(page).to have_css("span[data-track-event-category='Login']")
      expect(page).to have_css("span[data-track-event-action='Entrar']")
    end

    scenario 'Registration' do
      sign_up

      expect(page).to have_css("span[data-track-event-category='Registro']")
      expect(page).to have_css("span[data-track-event-action='Registrar']")
    end

    scenario 'Register as organization' do
      sign_up_as_organization

      expect(page).to have_css("span[data-track-event-category='Registro']")
      expect(page).to have_css("span[data-track-event-action='Registrar']")
    end

    scenario 'Up vote a debate', :js do
      user = create(:user)
      debate = create(:debate)

      login_as(user)
      visit debate_path(debate)


      find('.in-favor a').click
      expect(page).to have_css("span[data-track-event-category='Debate']")
      expect(page).to have_css("span[data-track-event-action='Votar']")
      expect(page).to have_css("span[data-track-event-name='Positivo']")
    end

    scenario 'Down vote a debate', :js do
      user = create(:user)
      debate = create(:debate)

      login_as(user)
      visit debate_path(debate)

      find('.against a').click
      expect(page).to have_css("span[data-track-event-category='Debate']")
      expect(page).to have_css("span[data-track-event-action='Votar']")
      expect(page).to have_css("span[data-track-event-name='Negativo']")
    end

    scenario 'Support a proposal', :js do
      user = create(:user, :level_two)
      proposal = create(:proposal)

      login_as(user)
      visit proposal_path(proposal)

      find('.in-favor a').click
      expect(page).to have_css("span[data-track-event-category='Propuesta']")
      expect(page).to have_css("span[data-track-event-action='Apoyar']")
      expect(page).to have_css("span[data-track-event-name='#{proposal.id}']")
    end

    scenario 'Proposal ranking', :js do
      user = create(:user, :level_two)

      medium = create(:proposal, title: 'Medium proposal')
      best   = create(:proposal, title: 'Best proposal')
      worst  = create(:proposal, title: 'Worst proposal')

      10.times { create(:vote, votable: best)   }
      5.times  { create(:vote, votable: medium) }
      2.times  { create(:vote, votable: worst)  }

      login_as(user)

      visit proposals_path
      click_link 'Best proposal'
      find('.in-favor a').click

      expect(page).to have_css("span[data-track-event-category='Propuesta']")
      expect(page).to have_css("span[data-track-event-action='Apoyar']")
      expect(page).to have_css("span[data-track-event-custom-value='1']")
      expect(page).to have_css("span[data-track-event-dimension='6']")
      expect(page).to have_css("span[data-track-event-dimension-value='1']")

      visit proposals_path
      click_link 'Medium proposal'
      find('.in-favor a').click

      expect(page).to have_css("span[data-track-event-custom-value='2']")
      expect(page).to have_css("span[data-track-event-dimension-value='2']")

      visit proposals_path
      click_link 'Worst proposal'
      find('.in-favor a').click

      expect(page).to have_css("span[data-track-event-custom-value='3']")
      expect(page).to have_css("span[data-track-event-dimension-value='3']")
    end

    scenario 'Create a proposal' do
      author = create(:user)
      login_as(author)

      visit new_proposal_path
      fill_in_proposal
      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'
      expect(page).to have_css("span[data-track-event-category='Propuesta']")
      expect(page).to have_css("span[data-track-event-action='Crear']")
    end

    scenario 'Comment a proposal', :js do
      user = create(:user)
      proposal = create(:proposal)

      login_as(user)
      visit proposal_path(proposal)

      fill_in "comment-body-proposal_#{proposal.id}", with: 'Have you thought about...?'
      click_button 'Publish comment'

      expect(page).to have_css("span[data-track-event-category='Propuesta']")
      expect(page).to have_css("span[data-track-event-action='Comentar']")
    end

    scenario 'Verify census' do
      user = create(:user)
      login_as(user)

      visit verification_path
      verify_residence

      expect(page).to have_css("span[data-track-event-category='Verificación']")
      expect(page).to have_css("span[data-track-event-action='Censo']")
    end

    scenario 'Verify sms' do
      user = create(:user, residence_verified_at: Time.now)
      login_as(user)

      visit verification_path
      confirm_phone

      expect(page).to have_css("span[data-track-event-category='Verificación']")
      expect(page).to have_css("span[data-track-event-action='SMS']")
    end

    scenario 'Delete account' do
      user = create(:user)
      login_as(user)

      visit users_registrations_delete_form_path
      click_button 'Erase my account'

      expect(page).to have_css("span[data-track-event-category='Baja']")
      expect(page).to have_css("span[data-track-event-action='Dar de baja']")
    end
  end

  context "Joaquin Reyes Landing" do

    context "Logged in user" do

      scenario 'Clicks on register' do
        user = create(:user)
        login_as(user)

        visit blas_bonilla_path
        click_link "Quiero registrarme"

        expect(current_path).to eq(blas_bonilla_path)
        expect(page).to have_css("span[data-track-event-category='Registro']")
        expect(page).to have_css("span[data-track-event-action='Ver formulario registro']")
        expect(page).to have_css("span[data-track-event-name='Landing Joaquin Reyes']")
      end

    end

    context "Not logged in user" do

      scenario 'Clicks on register' do
        visit blas_bonilla_path
        click_link "Quiero registrarme"

        expect(current_path).to eq(new_user_registration_path)
        expect(page).to have_css("span[data-track-event-category='Registro']")
        expect(page).to have_css("span[data-track-event-action='Ver formulario registro']")
        expect(page).to have_css("span[data-track-event-name='Landing Joaquin Reyes']")
      end

      scenario 'Registers successfully' do
        visit blas_bonilla_path
        click_link "Quiero registrarme"

        fill_in_signup_form
        click_button "Register"

        expect(page).to have_content "Thank you for registering"
        expect(page).to have_css("span[data-track-event-category='Registro']")
        expect(page).to have_css("span[data-track-event-action='Registrar']")
        expect(page).to have_css("span[data-track-event-name='Landing Joaquin Reyes']")
      end

    end
  end

  context "Home with Joaquin Reyes" do

    context "Not logged in user" do

      scenario 'Clicks on register', :js do
        visit root_path

        click_link "Register"

        expect(page).to have_css("span[data-track-event-category='Registro']")
        expect(page).to have_css("span[data-track-event-action='Ver formulario registro']")
        expect(page).to have_css("span[data-track-event-name='Home Joaquin Reyes']")
      end

      scenario 'Registers successfully', :js do
        visit root_path
        click_link "Register"

        fill_in_signup_form
        click_button "Register"

        expect(page).to have_content "Thank you for registering"
        expect(page).to have_css("span[data-track-event-category='Registro']")
        expect(page).to have_css("span[data-track-event-action='Registrar']")
        expect(page).to have_css("span[data-track-event-name='Home Joaquin Reyes']")
      end

    end
  end

  #Requires testing outgoing _paq.push call from track.js.coffee
  xscenario 'Track events on ajax call'

  #Requires testing outgoing _paq.push call from track.js.coffee
  xcontext 'Page view' do
    scenario 'Url'
    scenario 'Referer'
    scenario 'Title'
  end

  #Requires testing social network registrations
  xscenario 'Register with social network'

  #Requires testing method track_proposal from track.js.coffee
  xcontext 'Proposals' do
    scenario 'show' do
    end
  end

end