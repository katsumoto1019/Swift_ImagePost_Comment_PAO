import { Location } from "./location";
import { SpotRef } from "./spot";
import { Dictionary } from "./interfaces";
import { SpotUser } from "./spot-user";

export interface Board {
    id: string;
    timestamp: Date;
    location: Location;
    spots: Dictionary<SpotRef>;
    user: SpotUser;
    nestingLevel: number;
    parentBoardId?: string;
    title: string;
    hasNestedBoards: boolean;
}