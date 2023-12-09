# frozen_string_literal: true

require "test_helper"

class TestGoogleDriveManager < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def setup
    @session = GoogleDrive::Session.from_config("lib/res/gapi_config.json")
    @sheet = GoogleDriveManager::Sheet.new(@session, "1vKVuzAkApaDyChrAdbwNEewyCII0mzEFBaZWh51FV_A", 0)
    @new_sheet = GoogleDriveManager::Sheet.new(@session, "1vKVuzAkApaDyChrAdbwNEewyCII0mzEFBaZWh51FV_A", 1)
  end


  def test_rows
    assert_equal [["Prva Kolona", "Druga kolona", "Treca Kolona"], ["", "", ""], ["1", "25", "3"], ["4", "", "6"]], @sheet.rows
  end

  def test_row
    assert_equal ["1", "25", "3"], @sheet.row(2)
  end

  def test_each
    expected = ["Prva Kolona", "Druga kolona", "Treca Kolona", "", "", "", "1", "25", "3", "4", "", "6"]
    result = []
    @sheet.each { |cell| result << cell }
    assert_equal expected, result
  end
  
  def test_column_access
    assert_equal ["Prva Kolona", "", "1", "4"], @sheet["Prva Kolona"].to_a
  end

  def test_cell_access_and_assignment
    assert_equal "1", @sheet["Prva Kolona"][2]
    @sheet["Prva Kolona"][2] = "1"
    assert_equal "1", @sheet["Prva Kolona"][2]
  end

  def test_sum_and_avg
    assert_equal 5, @sheet.prva_kolona.sum
    assert_equal 1.25, @sheet.prva_kolona.avg
  end

  def test_find_row_by_value
    assert_equal 2, @sheet.prva_kolona["1"]
  end

  def test_map_select_reduce
    assert_equal [1, 1, 2, 5], @sheet.prva_kolona.map { |cell| cell.to_i + 1 }
    assert_equal ["1", "4"], @sheet["Prva Kolona"].select { |cell| cell.to_i > 0 }
    assert_equal "Prva Kolona14", @sheet["Prva Kolona"].reduce(:+)
  end

  def test_table_union
    @sheet + @new_sheet
  end

  def test_table_subtraction
    @sheet - @new_sheet
  end
end
