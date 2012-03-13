require 'rubygems'
require 'facets/string'

##
# Mixin to allow paths and options to be described as 'tags:' that are only pocessed
# when called for. the tag is satisfied by calls to self 
module Detagger
    attr_accessor :tagex

    def drill_down_ref(txt,target = self)
        return  unless txt 
        parm = txt.chomp(":").to_sym
        begin
            new_txt = target.send(parm) 
            raise "Self Reference" if new_txt == txt
            new_txt
        rescue NoMethodError
            txt
        end
    end
    
    def detag( value, target = self, resolved = [] )
        @tagex ||=  /([^\/:]+:)/

        if ( value.respond_to? :call )
            # manipulates self so that it is called with 'this' and not he context of the proc when defined
            value = target.instance_eval &value
        end

        if value && value.is_a?(String) 
            value = value.shatter(@tagex).flatten.map do |mtch|
                if mtch =~ @tagex
                    raise "Circular Reference" if resolved.include? mtch
                    new_value = drill_down_ref(mtch,target)
                    mtch == new_value ? new_value : detag(new_value, target, resolved + [mtch] )
                else
                    mtch
                end
            end
            if (value.uniq == [nil]) 
                value = nil
            else
                value = value.join
            end
        end
        value
    end

    def method_missing( method, *args, &blk )
        access, orig_method = *method.to_s.scan(/^(detag|raw)_(.+)$/).flatten
        unless orig_method && self.respond_to?(orig_method.to_sym )
            super(method,*args,&blk)
        else
            rawval = self.send( orig_method, *args, &blk ) 
            (access == "detag") ? detag( rawval ) : rawval  
        end
    end
    
    def unless_flag( flag, &blk )
        unless self.send("detag_#{flag}")
            yield blk
        else
           puts "\033[31m!! Skipping step due to #{flag.to_s.quote} being true...\033[0m"
           nil
        end
    end

    def if_flag( flag, &blk )
        if self.send( "detag_#{flag}" )
            yield blk
        else
            puts "\033[31m!! Skipping step due to #{flag.to_s.quote} being false...\033[0m"
            nil
        end
    end
end




