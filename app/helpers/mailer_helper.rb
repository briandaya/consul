module MailerHelper

  def commentable_url(commentable)
    return debate_url(commentable) if commentable.is_a?(Debate)
    return proposal_url(commentable) if commentable.is_a?(Proposal)
    return spending_proposal_url(commentable) if commentable.is_a?(SpendingProposal)
    return probe_probe_option_url(commentable.probe, commentable) if commentable.is_a?(ProbeOption)
  end

end
