import { SpotUser } from "./spot-user";

export interface User extends SpotUser {
    savedSpotsCount: number;
    uploadedSpotsCount: number;
}