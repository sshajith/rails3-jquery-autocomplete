module Rails3JQueryAutocomplete
  module Orm
    module Mongoid
       def get_autocomplete_order(methods, options, model=nil)
        order = options[:order]
        if order
          order.split(',').collect do |fields|
            sfields = fields.split
            [sfields[0].downcase.to_sym, sfields[1].downcase.to_sym]
          end
        else

          [  order_by_method(methods)  ]

        end
      end

      def order_by_method(methods)
        order = []
        methods.each do |method|
        order << [method.to_sym, :asc]
        end
        return order
      end

      def get_autocomplete_items(parameters)
        model   = parameters[:model]
        term    = parameters[:term]
        methods  = parameters[:methods]
        options = parameters[:options]
        is_full_search = options[:full]
        scopes  = Array(options[:scopes])
        limit   = get_autocomplete_limit(options)
        order   = get_autocomplete_order(methods, options, model)
        items = model.scoped

        scopes.each { |scope| items = items.send(scope) } unless scopes.empty?

        if is_full_search
          search = '.*' + term + '.*'
        else
          search = '^' + term
        end

        items_scoped = []
        scoped_criteria = []
        methods.each do | method |
        scoped_criteria <<  model.where(method.to_sym => /#{search}/i).limit(limit).order_by(order)
        end

        scoped_criteria.each do | criteria |
          criteria.each do |item|
            items_scoped << item
          end
        end

        return items_scoped
      end
    end
  end
end