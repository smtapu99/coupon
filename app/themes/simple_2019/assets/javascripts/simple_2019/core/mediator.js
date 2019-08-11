const mediator = (function() {

  let on = function(channel, fn) {
      let channels = channel.split(" ");

      channels.map((channel) => {
        if (!mediator.channels[channel]) mediator.channels[channel] = [];

        mediator.channels[channel].push({context: this, callback: fn});
      });

      return this;
    },

    trigger = function(channel) {
      if (!mediator.channels[channel]) return false;
      let args = Array.prototype.slice.call(arguments, 1);

      for (let i = 0, l = mediator.channels[channel].length; i < l; i++) {
        let subscription = mediator.channels[channel][i];
        subscription.callback.apply(subscription.context, args);
      }
      return this;
    };

  return {
    channels: {},
    trigger: trigger,
    on: on,
    installTo: function(obj) {
      obj.on = on;
      obj.trigger = trigger;
    }
  };

}());

export default mediator;
