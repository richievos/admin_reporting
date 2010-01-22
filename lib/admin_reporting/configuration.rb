module AdminReporting
  class Configuration
    def load_config(name)
      if name == 'reports'
        Admin::Report.class_eval &@reports_block
      elsif name == 'controller'
        Admin::ReportsController.class_eval &@controller_block
      end
    end

    def reports(&block)
      @reports_block ||= block
      load_config('reports')
    end

    def controller(&block)
      @controller_block ||= block
      load_config('controller')
    end
  end
end