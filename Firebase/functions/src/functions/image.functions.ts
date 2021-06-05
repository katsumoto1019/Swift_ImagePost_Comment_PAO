import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import * as gcs from '@google-cloud/storage';

import * as ffmpeg from 'fluent-ffmpeg';
import * as ffmpeg_static from 'ffmpeg-static';

import * as https from 'https';

import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';

import * as mkdirp from 'mkdirp';
import * as rimraf from 'rimraf';
import * as UUID from 'uuid/v4';

import * as dominantColor from 'dominant-color';
import { Spot } from '../models/spot';
import { SpotMediaItem } from '../models/spot-media-item';
import { User } from '../models/user';
import { UserImage } from '../models/user-image';
import { SpotUser } from '../models/spot-user';
import { createMongoDBSpot } from './spot.functions';
import { nodeApiUrl } from '../configs/node-api';

const THUMB_PREFIX = 'thumb_';

/*
Paths:
Profile Image:
users/{userId}/profileImages/{id}

Cover Image:
users/{userId}/coverImages/{id}

Spot Media:
users/{userId}/spots/{spotId}/media/{id}

Board Thumbnail:
users/{userId}/boards/{boardId}/media/thumbnail
*/

// export const imageUpdated = functions.storage.object().onMetadataUpdate(async (object, context) => {
//     console.log('version 0.0.4');
//     const fileBucket = object.bucket;
//     const filePath = object.name;
//     const contentType = object.contentType;
//     const metadata = object.metadata;

//     console.log(contentType, metadata);

//     if ((filePath.indexOf('media') == -1 && filePath.indexOf('Images') == -1) || (!contentType.startsWith('image/') && !contentType.startsWith('video/'))) {
//         console.log('media condition not met');
//         return;
//     }

//     const storagePath = 'gs://'.concat(path.join(fileBucket, filePath));
//     console.log('storagePath', storagePath);

//     if (contentType.startsWith('video/')) {
//         await generateVideoThumbnail(object, false);
//         return;
//     }
// })

export const imageUploaded = functions.storage.object().onFinalize(async (object, context) => {
    console.log('version 0.2');
    const fileBucket = object.bucket;
    const filePath = object.name;
    const contentType = object.contentType;
    const metadata = object.metadata;

    console.log(contentType, metadata);

    if ((filePath.indexOf('media') == -1 && filePath.indexOf('Images') == -1) || (!contentType.startsWith('image/') && !contentType.startsWith('video/'))) {
        console.log('media condition not met');
        return;
    }

    const storagePath = 'gs://'.concat(path.join(fileBucket, filePath));
    console.log('storagePath', storagePath);

    if (contentType.startsWith('video/')) {
        // await updateVideoThumbnail(object, filePath, fileBucket, metadata);
        return;
    }

    const servingUrl = await getServingUrl(storagePath);
    console.log('servingUrl', servingUrl);

    const placeholderColor = await getDominantColor(filePath, servingUrl);
    console.log('placeholderColor', placeholderColor);

    if (filePath.indexOf('spots') >= 0) {
        // const t1 = new Date();
        // await updateSpotMedia(filePath, servingUrl, placeholderColor, metadata);
        // const t2 = new Date();
        // console.log('spotUpdateTime', t2.getTime() - t1.getTime());
    } else if (filePath.indexOf('profileImages') >= 0 || filePath.indexOf('coverImages') >= 0) {
        await updateUserImage(filePath, servingUrl, placeholderColor);
    } else if (filePath.indexOf('boards') >= 0) {
        await updateBoardThumbnail(filePath, servingUrl, placeholderColor);
    }
});

// async function updateVideoThumbnail(object, filePath, fileBucket, metadata) {
//     const uuid = UUID();
//     const bucket = gcs().bucket(fileBucket);
//     const file = bucket.file(filePath);
//     await file.setMetadata({ metadata: { firebaseStorageDownloadTokens: uuid } });
//     const downloadUrl = "https://firebasestorage.googleapis.com/v0/b/" + fileBucket + "/o/" + encodeURIComponent(filePath) + "?alt=media&token=" + uuid;

//     const pathFragments = filePath.split('/');
//     const spotId = pathFragments[3];
//     const mediaId = path.basename(filePath).split('.')[0];
//     console.log(pathFragments, spotId, mediaId);

//     const collectionName = metadata && metadata.isNewSpot == true.toString() ? 'incompleteSpots' : 'spots';
//     const spotDocRef = admin.firestore().doc(`${collectionName}/${spotId}`);
//     await admin.firestore().runTransaction(async transaction => {
//         const spotDocSnapshot = await transaction.get(spotDocRef);
//         const spot = spotDocSnapshot.data() as Spot;

//         const currentSpotMediaItem: SpotMediaItem = spot.media[mediaId];
//         currentSpotMediaItem.placeholderColor = "#ffffff";
//         currentSpotMediaItem.url = downloadUrl;

//         spot.isMediaServed = true;
//         Object.keys(spot.media).forEach(spotMediaId => {
//             const spotMediaItem: SpotMediaItem = spot.media[spotMediaId];
//             if (spotMediaItem.url == null || (spotMediaItem.type == 1 && spotMediaItem.thumbnailUrl == null) || spotMediaItem.url.indexOf(`media/${spotMediaId}`) >= 0) {
//                 spot.isMediaServed = false;
//             }
//         });

//         transaction.update(spotDocRef, spot);
//     });

//     await generateVideoThumbnail(object);
// }

// async function updateSpotMedia(imagePath, servingUrl, placeholderColor, metadata) {
//     const pathFragments = imagePath.split('/');
//     const spotId = pathFragments[3];
//     const mediaId = path.basename(imagePath).replace(THUMB_PREFIX, '').split('.')[0];
//     console.log(pathFragments, spotId, mediaId);

//     const collectionName = metadata && metadata.isNewSpot == true.toString() ? 'incompleteSpots' : 'spots';
//     console.log('collectionName', collectionName);
//     console.log('metadata', metadata);
//     const spotDocRef = admin.firestore().doc(`${collectionName}/${spotId}`);
//     await admin.firestore().runTransaction(async transaction => {
//         const spotDocSnapshot = await transaction.get(spotDocRef);
//         const spot = spotDocSnapshot.data() as Spot;

//         console.log("updateSpotMedia spot:", spot);

//         if (spot == undefined || spot == null) {
//             return;
//         }

//         const currentSpotMediaItem: SpotMediaItem = spot.media[mediaId];
//         currentSpotMediaItem.placeholderColor = placeholderColor;
//         if (imagePath.indexOf(THUMB_PREFIX) >= 0) {
//             currentSpotMediaItem.thumbnailUrl = servingUrl;
//         } else {
//             currentSpotMediaItem.url = servingUrl;
//         }

//         spot.isMediaServed = true;
//         Object.keys(spot.media).forEach(spotMediaId => {
//             const spotMediaItem: SpotMediaItem = spot.media[spotMediaId];
//             if (spotMediaItem.url == null || (spotMediaItem.type == 1 && spotMediaItem.thumbnailUrl == null) || (spotMediaItem.type == 0 && spotMediaItem.url.indexOf(`media/${spotMediaId}`) >= 0)) {
//                 spot.isMediaServed = false;
//             }
//         });

//         transaction.update(spotDocRef, spot);

//         if (spot.isMediaServed && metadata.isNewSpot == true.toString()) {
//             createMongoDBSpot(spot);
//         }
//     });
// }

async function updateUserImage(imagePath, servingUrl, placeholderColor) {
    return new Promise((resolve, reject) => {
        const pathFragments = imagePath.split('/');
        const userId = pathFragments[1];
        const userImagePropertyName = pathFragments[2].substr(0, pathFragments[2].length - 1);
        const mediaId = path.basename(imagePath).split('.')[0];
        console.log(pathFragments, userId, mediaId);

        let user = {} as User;
        let userImage: UserImage = user[userImagePropertyName];
        if (userImage == null) {
            userImage = {} as UserImage;
            user[userImagePropertyName] = userImage;
        }
        userImage.id = mediaId;
        userImage.placeholderColor = placeholderColor;
        userImage.url = servingUrl;

        console.log('userImage', user);

        const request = require("request");

        const options = {
            method: 'POST',
            url: `${nodeApiUrl()}/me`,
            qs: { fid: userId },
            headers:
            {
                'Postman-Token': '742a1eab-b39b-410a-af3a-b7b0ed54991f',
                'Cache-Control': 'no-cache',
                'Content-Type': 'application/json'
            },
            body: user,
            json: true,
        };

        console.log('url', options.url);

        request(options, function (error, response, body) {
            console.log('body', body);
            if (error) {
                reject(error);
            }
            resolve();
        });
    });
}

// Utility

function getDominantColor(imagePath, servingUrl): Promise<string> {
    return new Promise(async (resolve, reject) => {
        const destination = path.dirname(imagePath);
        console.log('destination', destination);

        const fileName = path.basename(imagePath);

        const tmpDir = path.join(os.tmpdir(), destination);
        const downloadDir = path.join(tmpDir, 'download');
        const localImagePath = path.join(downloadDir, fileName);

        mkdirp.sync(downloadDir);

        let t1 = new Date();
        await downloadImage(servingUrl.concat('=s150'), localImagePath)
        let t2 = new Date();
        console.log('downloadTime', t2.getTime() - t1.getTime());

        t1 = new Date();
        dominantColor(localImagePath, function (err, color) {
            const hexColor = `#${color}`;
            t2 = new Date();
            console.log('placeolderColorTime', t2.getTime() - t1.getTime());

            rimraf.sync(localImagePath);
            resolve(hexColor);
        });
    });
}

function getServingUrl(storagePath) {
    return new Promise((resolve, reject) => {
        https.get(`https://${process.env.GCLOUD_PROJECT}.appspot.com/serve/image?url=${storagePath}`, res => {
            let body = '';
            res.on('data', chunk => {
                body += chunk;
            });

            res.on('end', () => {
                resolve(body);
            });
        });
    });
}

function downloadImage(url, destination) {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(destination);
        https.get(url, res => {
            res.pipe(file);
            file.on('finish', function () {
                file.close();
                resolve();
            });
        });
    });
}

async function generateVideoThumbnail(object, isNewSpot = true) {
    // File and directory paths.
    const filePath = object.name;
    const contentType = object.contentType; // This is the image MIME type
    const fileDir = path.dirname(filePath);
    const fileName = path.basename(filePath);
    const thumbFilePath = path.normalize(path.join(fileDir, `${THUMB_PREFIX}${fileName}`));
    const tempLocalFile = path.join(os.tmpdir(), filePath);
    const tempLocalDir = path.dirname(tempLocalFile);
    const tempLocalThumbFile = path.join(os.tmpdir(), thumbFilePath);

    // Cloud Storage files.
    const bucket = admin.storage().bucket(object.bucket);
    const file = bucket.file(filePath);
    const thumbFile = bucket.file(thumbFilePath);

    // Create the temp directory where the storage file will be downloaded.
    mkdirp.sync(tempLocalDir);

    // Download file from bucket.
    await file.download({ destination: tempLocalFile });
    console.log('The file has been downloaded to', tempLocalFile);
    // Generate a thumbnail using ImageMagick.
    let command = ffmpeg(tempLocalFile)
        .setFfmpegPath(ffmpeg_static.path)
        .outputOptions('-vframes 1')
        .outputOptions('-f image2pipe')
        .outputOptions('-vcodec png')
        .output(tempLocalThumbFile);

    await promisifyCommand(command);
    console.log('Thumbnail created at', tempLocalThumbFile);
    // Uploading the Thumbnail.
    //@ts-ignore
    await bucket.upload(tempLocalThumbFile, { destination: thumbFilePath, metadata: { contentType: 'image/jpeg', metadata: { isNewSpot: isNewSpot } } });
    console.log('Thumbnail uploaded to Storage at', thumbFilePath);
    // Once the image has been uploaded delete the local files to free up disk space.
    fs.unlinkSync(tempLocalFile);
    fs.unlinkSync(tempLocalThumbFile);
    // Get the Signed URLs for the thumbnail and original image.
    console.log('Thumbnail URLs saved to database.');
}

// Makes an ffmpeg command return a promise.
function promisifyCommand(command) {
    return new Promise((resolve, reject) => {
        command.on('end', resolve).on('error', reject).run();
    });
}

function updateBoardThumbnail(imagePath, servingUrl, placeholderColor) {
    const pathFragments = imagePath.split('/');
    const userId = pathFragments[1];
    const boardId = pathFragments[3];
    console.log('board thumbnail');
    console.log(pathFragments, userId, boardId);

    const request = require("request");

    const options = {
        method: 'PUT',
        url: `${nodeApiUrl()}/boards/${boardId}/thumbnail`,
        qs: { fid: userId },
        headers:
        {
            'Postman-Token': '742a1eab-b39b-410a-af3a-b7b0ed54991f',
            'Cache-Control': 'no-cache',
            'Content-Type': 'application/json'
        },
        body: { placeholderColor: placeholderColor, url: servingUrl },
        json: true
    };

    console.log('url', options.url);

    return request(options, function (error, response, body) {
        if (error) throw new Error(error);
        console.log('error', error);
        console.log('body', body);
    });
}