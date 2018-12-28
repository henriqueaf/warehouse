defmodule Warehouse.PackageTest do
  use ExUnit.Case
  alias Warehouse.Package
  doctest Warehouse.Package

  describe "#new" do
    test "return a new Package struct" do
      package_content = "package content"
      %Package{id: id, contents: contents} = Package.new(package_content)
      assert contents == package_content
      assert String.length(id) == 10
    end
  end

  describe "#random" do
    test "return a new Package struct with a random content" do
      %Package{id: _, contents: contents} = Package.random
      assert String.length(contents) > 0
    end
  end

  describe "#random_batch" do
    test "return a List with n numbers of Packages struct" do
      n = 5
      list = Package.random_batch(n)
      assert Enum.count(list) == n
      Enum.map(list, fn(package) ->
        assert %Package{} = package
      end)
    end
  end
end
