namespace :courts do
  desc "Add sample images to courts"
  task add_sample_images: :environment do
    courts = Court.all

    # 샘플 이미지 URL들 (실제 프로젝트에서는 실제 이미지 URL이나 파일 경로 사용)
    indoor_images = [
      "https://picsum.photos/800/600?random=1",
      "https://picsum.photos/800/600?random=2"
    ]

    outdoor_images = [
      "https://picsum.photos/800/600?random=3",
      "https://picsum.photos/800/600?random=4"
    ]

    courts.each do |court|
      if court.image1.blank? || court.image2.blank?
        if court.court_type == "indoor"
          court.update(
            image1: court.image1.presence || indoor_images[0],
            image2: court.image2.presence || indoor_images[1]
          )
          puts "Updated indoor court: #{court.name}"
        else
          court.update(
            image1: court.image1.presence || outdoor_images[0],
            image2: court.image2.presence || outdoor_images[1]
          )
          puts "Updated outdoor court: #{court.name}"
        end
      end
    end

    puts "Completed adding sample images to courts"
  end

  desc "Clear all court images"
  task clear_images: :environment do
    Court.update_all(image1: nil, image2: nil)
    puts "Cleared all court images"
  end
end
