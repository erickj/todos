require 'util/object_util'

RSpec.describe Util::ObjectUtil, :util do

  context :deep_equality_compare do

    class ObjectWithVars
      def initialize(vars = {})
        vars.each_pair do |k, v|
          instance_variable_set(("@" << k.to_s).intern, v)
        end
      end
    end

    it 'deeply compares comparables' do
      expect(Util::ObjectUtil.deep_equality_compare('b', 'b')).to be
      expect(Util::ObjectUtil.deep_equality_compare('b', 'c')).to be(false)

      expect(Util::ObjectUtil.deep_equality_compare(1, 1)).to be
      expect(Util::ObjectUtil.deep_equality_compare(1, 2)).to be(false)
    end

    it 'deeply compares like objects' do
      obj1 = ObjectWithVars.new :a => 'a', :b => 'b'
      obj2 = ObjectWithVars.new :a => 'a', :b => 'b'

      expect(Util::ObjectUtil.deep_equality_compare(obj1, obj1)).to be
      expect(Util::ObjectUtil.deep_equality_compare(obj1, obj2)).to be

      unlike_obj1 = ObjectWithVars.new :a => 'a'
      unlike_obj2 = ObjectWithVars.new :a => 'a', :b => 'c'

      expect(Util::ObjectUtil.deep_equality_compare(obj1, unlike_obj1)).to be(false)
      expect(Util::ObjectUtil.deep_equality_compare(obj1, unlike_obj2)).to be(false)
    end

    it 'deeply compares like arrays' do
      like_arrays = [
        ['a', Object.new, 9],
        ['a', Object.new, 9]
      ]
      expect(Util::ObjectUtil.deep_equality_compare([], [])).to be
      expect(Util::ObjectUtil.deep_equality_compare(like_arrays[0], like_arrays[1])).to be
      expect(Util::ObjectUtil.deep_equality_compare(like_arrays[0], like_arrays[0])).to be

      unlike_arrays = [
        [],
        [Object.new, 'a', 9],
        ['b', Object.new, 9]
      ]
      expect(Util::ObjectUtil.deep_equality_compare(like_arrays[0], unlike_arrays[0])).to be(false)
      expect(Util::ObjectUtil.deep_equality_compare(like_arrays[0], unlike_arrays[1])).to be(false)
      expect(Util::ObjectUtil.deep_equality_compare(like_arrays[0], unlike_arrays[2])).to be(false)
    end

    it 'deeply compares like hashes' do
      like_hashes = [
        {:a => 9, :b => [1, 2, 3], :c => {:x => 'x', :y => 'y'}},
        {:a => 9, :b => [1, 2, 3], :c => {:x => 'x', :y => 'y'}}
      ]
      expect(Util::ObjectUtil.deep_equality_compare(like_hashes[0], like_hashes[0])).to be
      expect(Util::ObjectUtil.deep_equality_compare(like_hashes[0], like_hashes[1])).to be

      unlike_hashes = [
        {:a => 9, :b => [1, 2, 3], :c => {:x => 'x', :y => 'ABC'}},
        {:a => 9, :b => [1, 2, 3]}
      ]
      expect(Util::ObjectUtil.deep_equality_compare(like_hashes[0], unlike_hashes[0])).to be(false)
      expect(Util::ObjectUtil.deep_equality_compare(like_hashes[0], unlike_hashes[1])).to be(false)
    end
  end
end
