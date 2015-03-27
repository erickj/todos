module Util
  module ObjectUtil

    class << self
      # Returns true if the instance variables of obj1 are deeply equal to
      # obj2.
      def deep_equality_compare(obj1, obj2)
        deep_equality_compare_internal(obj1, obj2, {})
      end

      private
      def deep_equality_compare_internal(obj1, obj2, object_id_pairs)
        prev_compare_result = check_if_compared(obj1, obj2, object_id_pairs)
        return prev_compare_result unless prev_compare_result.nil?

        if obj1.equal?(obj2)
          return store_compare_result(true, obj1, obj2, object_id_pairs)
        end


        if obj1.is_a? Comparable
          return store_compare_result(obj1 == obj2, obj1, obj2, object_id_pairs)
        end

        if obj1.is_a? Enumerable
          return store_compare_result(
                   deep_enumerable_compare_internal(obj1, obj2, object_id_pairs),
                   obj1,
                   obj2,
                   object_id_pairs)
        end

        obj1_instance_vars = obj1.instance_variables
        obj2_instance_vars = obj2.instance_variables

        unless obj1_instance_vars.size == obj2_instance_vars.size
          return store_compare_result(false, obj1, obj2, object_id_pairs)
        end

        obj1_instance_vars.each do |v_name|
          v1 = obj1.instance_variable_get(v_name);
          v2 = obj2.instance_variable_get(v_name);

          unless deep_equality_compare_internal(v1, v2, object_id_pairs)
            return store_compare_result(false, obj1, obj2, object_id_pairs)
          end
        end

        store_compare_result(true, obj1, obj2, object_id_pairs)
      end

      def deep_enumerable_compare_internal(enum1, enum2, object_id_pairs)
        prev_compare_result = check_if_compared(enum1, enum2, object_id_pairs)
        return prev_compare_result unless prev_compare_result.nil?

        if enum1.equal?(enum2)
          return store_compare_result(true, enum1, enum2, object_id_pairs)
        end

        unless enum1.is_a?(Enumerable) && enum2.is_a?(Enumerable)
          return store_compare_result(false, enum1, enum2, object_id_pairs)
        end

        entries1 = enum1.entries
        entries2 = enum2.entries
        unless entries1.size == entries2.size
          return store_compare_result(false, enum1, enum2, object_id_pairs)
        end

        entries1.each_index do |i|
          unless deep_equality_compare_internal(entries1[i], entries2[i], object_id_pairs)
            return store_compare_result(false, enum1, enum2, object_id_pairs)
          end
        end
        return store_compare_result(true, enum1, enum2, object_id_pairs)
      end

      def store_compare_result(result, obj1, obj2, object_id_pairs)
        object_id_pairs[obj1.object_id] ||= {}
        object_id_pairs[obj1.object_id][obj2.object_id] = !!result
      end

      def check_if_compared(obj1, obj2, object_id_pairs)
        ids = [obj1.object_id, obj2.object_id].sort

        # always store/compare in sorted order
        object_id_pairs[ids[0]][ids[1]] rescue nil
      end
    end
  end
end
