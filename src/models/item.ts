import { Author } from './author';

export class Item {
  public author: Author;
  public linkToThumbnail: URL;
  public id: number;
  constructor (
    public title: String,
    public linkToContent: URL,
    public contentHTML: String,
    public created: Date
  ) {}
}
