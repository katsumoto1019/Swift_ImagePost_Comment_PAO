import { Coordinate } from "./coordinate";
import { Dictionary } from "./dictionary";

export interface Location {
    about: string
    gmsAddress: Dictionary<string>;
    coordinate: Coordinate;
    googlePlaceId: string;
    name: string;
    formattedAddress: string;
}