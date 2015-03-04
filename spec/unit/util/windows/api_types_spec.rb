# encoding: UTF-8
#!/usr/bin/env ruby

require 'spec_helper'

describe "FFI::MemoryPointer", :if => Puppet.features.microsoft_windows? do
  context "read_wide_string" do
    let (:string) { "foo_bar" }

    it "should properly roundtrip a given string" do
      read_string = nil
      FFI::MemoryPointer.from_string_to_wide_string(string) do |ptr|
        read_string = ptr.read_wide_string(string.length)
      end

      expect(read_string).to eq(string)
    end

    it "should return a given string in UTF-8" do
      read_string = nil
      FFI::MemoryPointer.from_string_to_wide_string(string) do |ptr|
        read_string = ptr.read_wide_string(string.length)
      end

      expect(read_string.encoding).to eq(Encoding::UTF_8)
    end
  end
end
