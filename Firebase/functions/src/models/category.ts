import { SubCategory } from "./sub-category";
import { Dictionary } from "./dictionary";

export interface Category extends SubCategory {
    subCategories: Dictionary<SubCategory>;
}