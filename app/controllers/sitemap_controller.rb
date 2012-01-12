class SitemapController < ::Refinery::FastController
  layout nil

  def index
    headers['Content-Type'] = 'application/xml'

    respond_to do |format|
      format.xml do
        @locales = [I18n.locale]
                  # if Refinery.i18n_enabled?
                  #    Refinery::I18n.frontend_locales
                  #  else
                  #    [I18n.locale]
                  #  end
      end
    end
  end

end
