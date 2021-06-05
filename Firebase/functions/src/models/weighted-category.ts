import { WeightedSubCategory } from "./weighted-sub-category";
import { Dictionary } from "./dictionary";

export interface WeightedCategory extends WeightedSubCategory {
    subCategories: Dictionary<WeightedSubCategory>;
}