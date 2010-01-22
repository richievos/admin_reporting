module AdminReporting
  class ReportsController < ApplicationController
    unloadable

    def show
      @reports = Report.report_names
      @report = Report.run(params['id'])
    end
  end
end
# hackervision: need to rerun any configuration that was set since it would have
# been removed during class reloading
AdminReporting.configuration.load_config("reports")