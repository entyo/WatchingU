export class Item {
  public linkToThumbnail: URL;
  public id: number;
  public personId: number;
  constructor (
    public title: String,
    public linkToContent: URL,
    public contentHTML: String,
    public created: Date
  ) {}
}
