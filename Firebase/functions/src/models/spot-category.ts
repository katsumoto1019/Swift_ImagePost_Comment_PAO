import { Dictionary } from "./dictionary";
import { SpotSubCategory } from "./spot-sub-category";

export interface SpotCategory extends SpotSubCategory {
    id: string;
    index: number;
    subCategories: Dictionary<SpotSubCategory>;
}