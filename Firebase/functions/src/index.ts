import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase);

import * as imageFunctions from './functions/image.functions';
import * as spotFunctions from './functions/spot.functions';

import { app } from './app.express';
import { nodeApiUrl } from './configs/node-api';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
export const helloWorld = functions.https.onRequest((request, response) => {
    // response.send("Hello from Firebase!");
    response.send(nodeApiUrl());
});


export const api = functions.https.onRequest(app);

export const imageUploaded = imageFunctions.imageUploaded;
// export const imageUpdated = imageFunctions.imageUpdated;