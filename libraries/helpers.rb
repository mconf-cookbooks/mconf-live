#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

module FFMPEG
  module Helpers
    def find_prerequisite_packages_by_flags(compile_flags)
      packages = ["libxext-dev", "libxfixes-dev"]
      compile_flags.each do |flag|
        packages = packages |= packages_for_flag(flag)
      end

      packages
    end
  end
end

# Chef class
class Chef
  # Recipe class
  class Recipe
    include FFMPEG::Helpers
  end
end
