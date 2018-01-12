import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Item } from './shared/models/item';
import 'rxjs/add/operator/map';
import { Observable } from 'rxjs/Observable';
import { Observer } from 'rxjs/Observer';
import { TimerObservable } from 'rxjs/observable/TimerObservable';

interface Response {
  description: string;
  link: string;
  pubDate: string;
  title: string;
  enclosure: {
    length: string,
    type: string,
    url: string
  };
}

@Injectable()
export class HatenaService {

  constructor(private http: HttpClient) { }

  fetchItems(username: string): Observable<Item[]> {
    const user = username;
    const query = `select * from rss where url='http://${user}.hatenablog.com/rss'`;
    const format = 'json';
    const url = `https://query.yahooapis.com/v1/public/yql?q=${query}&format=${format}`;
    return this.http.get(url).map(res => {
      if (!res['query']['count']) {
        throw new Error('Failed to fetch hatena posts: ' + url);
      }
      const responses: Response[] = res['query']['results']['item'];

      const items = responses.map((payload: Response) => {
        const item = new Item(
          payload.title,
          new URL(payload.link),
          payload.description,
          new Date(payload.pubDate)
        );

        const enc = payload.enclosure;
        if (enc.type.includes('image') && enc.length) {
          item.linkToThumbnail = new URL(enc.url);
        }
        return item;
      });

      return items;
    })
    .catch((err, items) => {
      // console.log(err);
      return Observable.of([]);
    });
  }

}
