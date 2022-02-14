const {PubSub} = require('@google-cloud/pubsub');

const pubSubClient = new PubSub();

const listenForMessages = () => {
  // References an existing subscription
  const subscription = pubSubClient.subscription('android_subscription_topic_test-sub');

  // Create an event handler to handle messages
  let messageCount = 0;
  const messageHandler = message => {
    console.log(`Received message ${message.id}:`);
    console.log(`\tData: ${message.data}`);
    console.log(`\tAttributes: `);
    console.log(message.attributes);
    messageCount += 1;

    message.ack();
  };

  subscription.on('message', messageHandler);

  setTimeout(() => {
    subscription.removeListener('message', messageHandler);
    console.log(`${messageCount} message(s) received.`);
  }, 90 * 1000);
}

listenForMessages();