import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Item } from '../models/item';
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
  }
}

@Injectable()
export class HatenaService {

  constructor(private http: HttpClient) { }

  fetchItems(): Observable<Item[]> {
    const user = 'hyuki';
    const query = `select * from rss where url='http://${user}.hatenablog.com/rss'`;
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
            res.description,
            new Date(res.pubDate)
          );

          const enc = res.enclosure;
          if (enc.type.includes('image') && enc.length) {
            item.linkToThumbnail = new URL(enc.url);
          }
          return item;
        });

        observer.next(items);
        observer.complete();
      });
    });
  }

}
