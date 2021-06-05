import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { Spot } from '../models/spot';
import { nodeApiUrl } from '../configs/node-api';

async function deleteSpotMedia(spot: Spot) {
    const promises = [];
    Object.keys(spot.media).forEach(mediaId => {
        const promise = admin.storage().bucket().file(`users/${spot.user.id}/spots/${spot.id}/media/${mediaId}`).delete();
        promises.push(promise);
    });

    await Promise.all(promises);
}

export function createMongoDBSpot(spot: Spot) {
    console.log('spot:', spot);

    const request = require("request");

    const options = {
        method: 'POST',
        url: `${nodeApiUrl()}/spots`,
        qs: { fid: spot.user.id },
        headers:
        {
            'Postman-Token': '742a1eab-b39b-410a-af3a-b7b0ed54991f',
            'Cache-Control': 'no-cache',
            'Content-Type': 'application/json'
        },
        body: spot,
        json: true
    };

    request(options, function (error, response, body) {
        if (error) throw new Error(error);
        console.log('error', error);
        console.log('body', body);
    });
}