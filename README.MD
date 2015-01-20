# DHL package pushbullet notifier

You have a german DHL tracking number and want to get updates about your package via [pushbullet](https://www.pushbullet.com/)? This might be the solution you are looking for!

## Full usage
    Usage: dhl-notifier [options]
        -p, --pushsbullet-token TOKEN    Your pushbullet api token
        -r, --reference-number REFERENCE Your DHL reference number
        -s, --sleep SLEEP                Interval between two checks for status updates (default 30 minutes)
            --test-pushbullet            Push a test notification and exit
        -h, --help                       Display this screen

## Test pushbullet notification
    ./dhl-notifier.rb -p <PUSHBULLET_TOKEN_HERE> --test-pushbullet

## Setup & run

    bundle install
    ./dhl-notifier.rb -p <PUSHBULLET_TOKEN_HERE> -r <DHL_REFERENCE_NUMBER_HERE>

## Questions || feedback?
Drop me a message.
