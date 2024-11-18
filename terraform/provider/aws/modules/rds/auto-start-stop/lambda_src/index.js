const AWS = require('aws-sdk');

const rds = new AWS.RDS();

exports.handler = async (event, context) => {
    try {
        console.log(event)
        const isScheduledEvent = event['detail-type'] === 'Scheduled Event' && event['source'] === 'aws.events';

        if (isScheduledEvent) {
            const detail = event.detail || {};
            const resourceARN = event['resources'][0]
            const modeUpdateValue = resourceARN.split("/")[1]
            console.log('MODE_UPDATE: ', modeUpdateValue)

            const instanceIdsJson = process.env.DB_INSTANCE_IDS;

            if (!instanceIdsJson) {
                console.log('Missing DB_INSTANCE_IDS environment variable.');
                return;
            }

            const instanceIds = JSON.parse(instanceIdsJson);

            for (const dbInstanceIdentifier of instanceIds) {
                if (modeUpdateValue === 'rds-scheduler-rule_down') {
                    await stopRDSInstance(dbInstanceIdentifier);
                    console.log(`Paused RDS cluster ${dbInstanceIdentifier}`);
                } else if (modeUpdateValue === 'rds-scheduler-rule_live') {
                    await startRDSInstance(dbInstanceIdentifier);
                    console.log(`Resumed RDS cluster ${dbInstanceIdentifier}`);
                } else {
                    console.log('Unsupported MODE_UPDATE value.');
                }
            }
        } else {
            console.log('Unsupported event type or missing detail in event.');
        }
    } catch (error) {
        console.error('Error:', error);
    }
};

async function pauseDBCluster(dbInstanceIdentifier) {
    try {
        await rds.stopDBCluster({ DBClusterIdentifier: dbInstanceIdentifier }).promise();
    } catch (error) {
        console.error(`Error pausing Aurora cluster ${dbInstanceIdentifier}:`, error);
        throw error;
    }
}

async function resumeDBCluster(dbInstanceIdentifier) {
    try {
        await rds.startDBCluster({ DBClusterIdentifier: dbInstanceIdentifier }).promise();
    } catch (error) {
        console.error(`Error resuming Aurora cluster ${dbInstanceIdentifier}:`, error);
        throw error;
    }
}

async function startRDSInstance(dbInstanceIdentifier) {
    try {
        await rds.startDBInstance({ DBInstanceIdentifier: dbInstanceIdentifier }).promise();
    } catch (error) {
        console.error(`Error starting RDS instance ${dbInstanceIdentifier}:`, error);
        throw error;
    }
}

async function stopRDSInstance(dbInstanceIdentifier) {
    try {
        await rds.stopDBInstance({ DBInstanceIdentifier: dbInstanceIdentifier }).promise();
    } catch (error) {
        console.error(`Error stopping RDS instance ${dbInstanceIdentifier}:`, error);
        throw error;
    }
}