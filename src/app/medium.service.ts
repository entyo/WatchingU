import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Item } from './shared/models/item';
import 'rxjs/add/operator/map';
import 'rxjs/add/observable/of';
import { Observable } from 'rxjs/Observable';
import { Observer } from 'rxjs/Observer';

interface Response {
  creator: string;
  encoded: string;
  link: string;
  pubDate: string;
  title: string;
  updated: string;
}

@Injectable()
export class MediumService {

  constructor(private http: HttpClient) { }

  fetchItems(username: string): Observable<Item[]> {
    const user = username;
    const query = `select * from rss where url='https://medium.com/feed/@${user}'`;
    const format = 'json';
    const url = `https://query.yahooapis.com/v1/public/yql?q=${query}&format=${format}`;

    return this.http.get(url)
    .map(res => {
      if (!res['query']['count']) {
        throw new Error('Failed to fetch medium posts: ' + url);
      }
      const responses: Response[] = res['query']['results']['item'];

      const items = responses.map((payload: Response) => {
        return new Item(
          payload.title,
          new URL(payload.link),
          payload.encoded,
          new Date(payload.pubDate)
        );
      });

      return items;
    })
    .catch((err, items) => {
      // console.log(err);
      return Observable.of([]);
    });
  }
}