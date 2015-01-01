require "the_data_role_block_haml_41/version"

module TheDataRoleBlockHaml41
  class Engine < ::Rails::Engine
    initializer 'data-role-block-haml.register' do |app|
      if defined?(Haml::Parser)
        class Haml::Parser
          DIV_ROLE  = '@'
          DIV_BLOCK = '@@'

          DIV_ROLE_ATTR  = 'data-role'
          DIV_BLOCK_ATTR = 'data-block'

          private

          original_process_line_method = instance_method :process_line

          define_method :process_line do |line|
            if (line.text.slice(0,2) === DIV_BLOCK) || (line.text[0] === DIV_ROLE)
              push div(line.text)
            else
              original_process_line_method.bind(self).call(line)
            end
          end

          def self.parse_class_and_id(list)
            attributes = {}
            return attributes if list.empty?

            list.scan(/(#|\.|@|@@])([-:_a-zA-Z0-9]+)/) do |type, property|
              case type
                when '#'; attributes[ID_KEY] = property

                when '.'
                  if attributes[CLASS_KEY]
                    attributes[CLASS_KEY] += " "
                  else
                    attributes[CLASS_KEY] = ""
                  end
                  attributes[CLASS_KEY] += property

                when DIV_ROLE
                  if attributes[DIV_ROLE_ATTR]
                    attributes[DIV_ROLE_ATTR] += " "
                  else
                    attributes[DIV_ROLE_ATTR] = ""
                  end
                  attributes[DIV_ROLE_ATTR] += property

                when DIV_BLOCK
                  if attributes[DIV_BLOCK_ATTR]
                    attributes[DIV_BLOCK_ATTR] += " "
                  else
                    attributes[DIV_BLOCK_ATTR] = ""
                  end
                  attributes[DIV_BLOCK_ATTR] += property
                end
              end
            end
            attributes
          end

          def parse_tag(text)
            # match = line.scan(/%([-:\w]+)([-:\w\.\#\@]*)(.*)/)[0]

            match = text.scan(/%([-:\w]+)([-:\w.#@]*)(.+)?/)[0]
            raise SyntaxError.new(Error.message(:invalid_tag, text)) unless match

            tag_name, attributes, rest = match

            if !attributes.empty? && (attributes =~ /[.#](\.|#|\z)/)
              raise SyntaxError.new(Error.message(:illegal_element))
            end

            new_attributes_hash = old_attributes_hash = last_line = nil
            object_ref = :nil
            attributes_hashes = {}
            while rest && !rest.empty?
              case rest[0]
              when ?{
                break if old_attributes_hash
                old_attributes_hash, rest, last_line = parse_old_attributes(rest)
                attributes_hashes[:old] = old_attributes_hash
              when ?(
                break if new_attributes_hash
                new_attributes_hash, rest, last_line = parse_new_attributes(rest)
                attributes_hashes[:new] = new_attributes_hash
              when ?[
                break unless object_ref == :nil
                object_ref, rest = balance(rest, ?[, ?])
              else; break
              end
            end

            if rest && !rest.empty?
              nuke_whitespace, action, value = rest.scan(/(<>|><|[><])?([=\/\~&!])?(.*)?/)[0]
              if nuke_whitespace
                nuke_outer_whitespace = nuke_whitespace.include? '>'
                nuke_inner_whitespace = nuke_whitespace.include? '<'
              end
            end

            if @options.remove_whitespace
              nuke_outer_whitespace = true
              nuke_inner_whitespace = true
            end

            if value.nil?
              value = ''
            else
              value.strip!
            end
            [tag_name, attributes, attributes_hashes, object_ref, nuke_outer_whitespace,
             nuke_inner_whitespace, action, value, last_line || @line.index + 1]
          end

        end
      end
    end
  end
end
