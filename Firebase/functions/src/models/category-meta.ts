import { SubCategoryMeta } from "./sub-category-meta";

export interface CategoryMeta extends SubCategoryMeta {
    count: number;
    subCategories: object;
}