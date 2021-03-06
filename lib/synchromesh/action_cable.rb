module ApplicationCable
  class Channel < ActionCable::Channel::Base; end
  class Connection < ActionCable::Connection::Base; end
end

module HyperMesh
  class ActionCableChannel < ApplicationCable::Channel
    class << self
      def subscriptions
        @subscriptions ||= Hash.new { |h, k| h[k] = 0 }
      end
    end

    def inc_subscription
      self.class.subscriptions[params[:synchromesh_channel]] =
        self.class.subscriptions[params[:synchromesh_channel]] + 1
    end

    def dec_subscription
      self.class.subscriptions[params[:synchromesh_channel]] =
        self.class.subscriptions[params[:synchromesh_channel]] - 1
    end

    def subscribed
      session_id = params["client_id"]
      authorization = HyperMesh.authorization(params["salt"], params["synchromesh_channel"], session_id)
      if params["authorization"] == authorization
        inc_subscription
        stream_from "synchromesh-#{params[:synchromesh_channel]}"
      else
        reject
      end
    end

    def unsubscribed
      HyperMesh::Connection.disconnect(params[:synchromesh_channel]) if dec_subscription == 0
    end
  end
end
