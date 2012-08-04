module Rails3JQueryAutocomplete
  module Orm
    module ActiveRecord
      def get_autocomplete_order(methods, options, model=nil)
        order = options[:order]

        table_prefix = model ? "#{model.table_name}." : ""
        methods.each do |method|
          order || " #{table_prefix}#{method} ASC"
        end
      end

      def get_autocomplete_items(parameters)
        model   = parameters[:model]
        term    = parameters[:term]
        methods  = parameters[:methods]
        options = parameters[:options]
        scopes  = Array(options[:scopes])
        limit   = get_autocomplete_limit(options)
        order   = get_autocomplete_order(methods, options, model)


        items = model.scoped

        scopes.each { |scope| items = items.send(scope) } unless scopes.empty?

        items = items.select(get_autocomplete_select_clause(model, methods, options)) unless options[:full_model]
        items = items.where(get_autocomplete_where_clause(model, term, methods, options)).
            limit(limit).order(order)
      end

      def get_autocomplete_select_clause(model, methods, options)
        table_name = model.table_name
        select_clause=["#{table_name}.#{model.primary_key}"]
        options[:extra_data].each do |method|
          select_clause.push "#{table_name}.#{method}"
        end unless options[:extra_data].blank?
        methods.each do |method|
          select_clause.push "#{table_name}.#{method}"
        end


        return select_clause
      end

      def get_autocomplete_where_clause(model, term, methods, options)
        table_name = model.table_name
        is_full_search = options[:full]
        like_clause = (postgres? ? 'ILIKE' : 'LIKE')
        where_text="1>1"
        methods.each do |method|
          where_text+=" OR LOWER(#{table_name}.#{method}) #{like_clause} :term"
        end
        [where_text, {:term=>"#{(is_full_search ? '%' : '')}#{term.downcase}%"}]
      end

      def postgres?
        defined?(PGconn)
      end
    end
  end
end