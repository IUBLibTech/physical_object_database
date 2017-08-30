class ChangeFilmResolutionSepmagToAudioOnly < ActiveRecord::Migration
  def up
    update_film_tms(resolution: { old: 'Sepmag', new: 'Audio only' })
  end
  def down
    update_film_tms(resolution: { old: 'Audio only', new: 'Sepmag' })
  end
  def update_film_tms(atts)
    atts.each do |att, values|
       puts "Updating #{att} values: #{values[:old]}->#{values[:new]}"
       tms = FilmTm.where(att => values[:old])
       print "#{tms.size} records:"
       tms.each do |tm|
         tm.send("#{att}=", values[:new])
         tm.save(validate: false)
         print '.'
       end
    end
    puts ''
  end
end
