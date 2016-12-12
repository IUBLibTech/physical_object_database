class RenameNewUnits < ActiveRecord::Migration
  UNIT_ABBREVIATIONS = {
    'IN-LIBR-SCA' => 'I-LIBR-SCA',
    'IN-RAYBRAD' => 'I-RAYBRAD',
    'IN-DENT' => 'I-DENT',
    'EA-ARCHIVE' => 'EA-ARCHIVES',
    'EA-ATHL' => 'EA-ATHL',
    'KO-ARCHIVE' => 'KO-ARCHIVES',
    'NW-ARCHIVE' => 'NW-ARCHIVES',
    'SE-ARCHIVE' => 'SE-ARCHIVES',
    'SB-ARCHIVE' => 'SB-ARCHIVES',
  }
  def up
    UNIT_ABBREVIATIONS.each do |old, new|
      puts "#{old} => #{new}"
      u = Unit.where(abbreviation: old).first
      u.update_attributes!(abbreviation: new)
    end
  end
  def down
    UNIT_ABBREVIATIONS.each do |old, new|
      puts "#{new} => #{old}"
      u = Unit.where(abbreviation: new).first
      u.update_attributes!(abbreviation: old)
    end
  end
end
