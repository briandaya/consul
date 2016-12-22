module TracksHelper

  def event_data_for(key)
    session[:event][key.to_sym] || session[:event][key.to_s]
  end

  def gender(user)
    if user.gender.present?
      I18n.t("tracking.user_data.gender.#{user.gender}")
    else
      I18n.t("tracking.user_data.gender.unknown")
    end
  end

  def age(user)
    if user.date_of_birth.blank?
      I18n.t("tracking.user_data.age.unknown")
    else
      ((Date.today - user.date_of_birth.to_date).to_i / 365.25).to_i
    end
  end

  def verification_level(user)
    case
    when user.level_three_verified?
      I18n.t("tracking.user_data.verification_level.level_three")
    when user.level_two_verified?
      I18n.t("tracking.user_data.verification_level.level_two")
    else
      I18n.t("tracking.user_data.verification_level.level_one")
    end
  end

  def geozone(user)
    current_user.try(:geozone).try(:name) || I18n.t("tracking.user_data.district.unknown")
  end

end
