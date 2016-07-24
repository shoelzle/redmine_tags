module RedmineTags
  module Hooks
    class ViewsWikiHook < Redmine::Hook::ViewListener
      def view_layouts_base_body_bottom(context = {})
        controller = context[:controller]
        action = controller.action_name
        request = context[:request]
        hook_res = ''
        if controller.is_a? WikiController
          context[:page] = controller.instance_variable_get '@page'
          return '' unless context[:page]
          if action == 'show'
            # for some reason action show is used for creating new wiki pages
            if context[:page].instance_variable_get '@new_record'
              hook_res = view_wiki_form_bottom context
              scripts = ''
              hook_res.scan(/<script.*<\/script>/m) {|m| scripts += m }
              hook_res.gsub! /<script.*<\/script>/m, ' '
              hook_res.gsub! /\n/, " \\\n"
              hook_res = javascript_tag "$('#content_comments').parent().after('#{ hook_res }')"
              hook_res += scripts.html_safe
            else
              hook_res = view_wiki_show_bottom context
              scripts = ''
              hook_res.scan(/<script.*<\/script>/m) {|m| scripts += m }
              hook_res.gsub! /<script.*<\/script>/m, ' '
              hook_res.gsub! /\n/, " \\\n"
              hook_res = javascript_tag "$('.attachments').before('#{ hook_res }')"
              hook_res += scripts.html_safe
            end
          elsif action == 'edit'
            hook_res = view_wiki_form_bottom context
            scripts = ''
            hook_res.scan(/<script.*<\/script>/m) {|m| scripts += m }
            hook_res.gsub! /<script.*<\/script>/m, ' '
            hook_res.gsub! /\n/, " \\\n"
            hook_res = javascript_tag "$('#content_comments').parent().after('#{ hook_res }')"
            hook_res += scripts.html_safe
          end
        end
        return hook_res
      end

      # Why wiki doesnt have this hooks? :(
      def view_wiki_show_bottom(context = {})
        context[:controller].send :render_to_string, { partial: 'wiki/tags',
          locals: { page: context[:page] } }
      end

      def view_wiki_form_bottom(context = {})
        context[:controller].send :render_to_string, { partial: 'wiki/tags_form',
          locals: { page: context[:page] } }
      end

      def view_layouts_base_sidebar(context = {})
        controller = context[:controller]
        context[:page] = controller.instance_variable_get '@page'
        action = controller.action_name
        if controller.is_a?(WikiController) &&
           (action == 'index' || action == 'show' || action == 'date_index')
          return context[:controller].send :render_to_string, {
            partial: 'wiki/tags_sidebar', locals: { page: context[:page] } }
        end
        return ''
      end
    end
  end
end
