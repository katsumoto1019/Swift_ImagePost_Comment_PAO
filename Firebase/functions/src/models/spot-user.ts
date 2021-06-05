import { UserImage } from "./user-image";

export interface SpotUser {
    id: string;
    
    name: string;
    username: string;
    
    coverImage: UserImage;
    profileImage: UserImage;
}