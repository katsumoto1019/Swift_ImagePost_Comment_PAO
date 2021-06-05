import { SpotRef } from "./spot";
import { SpotUser } from "./spot-user";

export interface Notification {
    id: string;
    timestamp: Date;
    spot: SpotRef;
    user: SpotUser;
}