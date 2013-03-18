name             'ceilometer'
maintainer       'ng'
maintainer_email 'email@kt.com'
license          'All rights reserved'
description      'Installs/Configures ceilometer'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
%w{ ubuntu }.each do |os|
  supports os
end

%w{ osops }.each do |dep|
  depends dep
end

