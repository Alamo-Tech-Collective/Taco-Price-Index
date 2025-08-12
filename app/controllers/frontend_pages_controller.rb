class FrontendPagesController < ApplicationController
  allow_unauthenticated_access :map

  def map
    @restaurants = Restaurant.all
    @user = Current.session&.user
  end
end
