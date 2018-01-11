import { Injectable } from '@angular/core';

import { HttpClient } from '@angular/common/http';
import { Item } from './shared/models/item';
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
    }[];
  };
}

@Injectable()
export class SlideShareService {
  constructor(private http: HttpClient) {}

  fetchItems(username: string): Observable<Item[]> {
    const user = username;
    const query = `select * from rss where url='https://www.slideshare.net/rss/user/${user}'`;
    const format = 'json';
    const url = `https://query.yahooapis.com/v1/public/yql?q=${query}&format=${format}`;
    return Observable.create((observer: Observer<Item[]>) => {
      this.http.get(url)
      .subscribe(res => {
        if (!res['query']['count']) {
          observer.error(new Error('Failed to fetch slideshare posts: ' + url));
          return;
        }
        const responses: Response[] = res['query']['results']['item'];

        const items = responses.map((payload: Response) => {
          const item = new Item(
            payload.title,
            new URL(payload.link),
            payload.content.description.content,
            new Date(payload.pubDate)
          );

          if (payload.content.thumbnail.length) {
            // cdn.slidesharecdn.com/ss_thumbnails/glsl-171106154757-thumbnail-2.jpg?hoge=fuga
            item.linkToThumbnail = new URL('https://' + payload.content.thumbnail[0].url);
          }
          return item;
        });

        observer.next(items);
      });
    });
  }
}
