import { Author } from './author';

export class Item {
  author: Author;
  public linkToThumbnail: URL;
  constructor (
    public title: String,
    public linkToContent: URL,
    public contentHTML: String,
    public created: Date
  ) {}
}
