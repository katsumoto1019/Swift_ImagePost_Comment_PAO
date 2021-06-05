import { Dictionary } from "./dictionary";

export interface UserSettings {
    id: string;
    notificationTokens: Dictionary<string>;
    email: string;
    unreadNotificationsCount: number;
    isPushNotificationsEnabled: boolean;
}