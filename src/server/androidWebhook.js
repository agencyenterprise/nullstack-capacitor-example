const {PubSub} = require('@google-cloud/pubsub');

const pubSubClient = new PubSub();
const SUBSCRIPTION_ID = 'android_subscription_topic_test-sub';

const SECONDS = 90 * 1000;

const listenForMessages = () => {
  const subscription = pubSubClient.subscription(SUBSCRIPTION_ID);

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
  }, SECONDS);
}

listenForMessages();