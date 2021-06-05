import { SpotUser } from "./spot-user";
import { Location } from "./location";
import { SpotCategory } from "./spot-category";

export interface SpotRef {
    id: string;
    timestamp: Date;
    media: any;
}

export interface Spot extends SpotRef {
    description: string;
    location: Location;
    category: SpotCategory;
    saves: number;
    mediaCount: number;
    imagesCount: number;
    videosCount: number;
    isMediaServed: boolean;
    user: SpotUser;
}