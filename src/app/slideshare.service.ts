import { Injectable } from '@angular/core';

import { HttpClient } from '@angular/common/http';
import { Item } from '../models/item';
import 'rxjs/add/operator/map'; 
import { Observable } from 'rxjs/Observable';
import { Observer } from 'rxjs/Observer';

interface Response {
  author: string;
  title: string;
  link: string;
  pubDate: string;
  content: {
    description: {
      type: string;
      content: string;
    };
    thumbnail: {
      width: string,
      height: string,
      url: string
    }[]
  }
}

@Injectable()
export class SlideShareService {
  constructor(private http: HttpClient) {}

  fetchItems(): Observable<Item[]> {
    const user = 'e_ntyo';
    const query = `select * from rss where url='https://www.slideshare.net/rss/user/${user}'`;
    const format = 'json';
    const url = `https://query.yahooapis.com/v1/public/yql?q=${query}&format=${format}`;
    return Observable.create((observer: Observer<Item[]>) => {
      this.http
      .get(url)
      .subscribe(res => {
        const responses: Response[] = res['query']['results']['item'];
        if (!responses) {
          observer.error(new Error('Failed to fetch medium posts.'));
          return;
        }
 
        const items = responses.map((res: Response) => {
          const item = new Item(
            res.title,
            new URL(res.link),
            res.content.description.content,
            new Date(res.pubDate)
          );

          if (res.content.thumbnail.length) {
            // cdn.slidesharecdn.com/ss_thumbnails/glsl-171106154757-thumbnail-2.jpg?hoge=fuga
            item.linkToThumbnail = new URL('https://' + res.content.thumbnail[0].url);
          }
          return item;
        });

        observer.next(items);
        observer.complete();
      });
    });
  }
}
