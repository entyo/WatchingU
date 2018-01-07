import { Injectable } from '@angular/core';
import { HttpClient } from "@angular/common/http";
import { Item } from "../models/item";
import 'rxjs/add/operator/map'; 
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

  fetchItems(): Observable<Item> {
    const user = 'r7kamura';
    const query = `select * from rss where url='https://medium.com/feed/@${user}'`;
    const format = 'json';
    const url = `https://query.yahooapis.com/v1/public/yql?q=${query}&format=${format}`;
    return Observable.create((observer: Observer<Item>) => {
      this.http
      .get(url)
      .subscribe(res => {
        const responses: Response[] = res['query']['results']['item'];
        if (!responses) {
          observer.error(new Error('Failed to fetch medium posts.'));
          return;
        }

        responses
        .map(res => new Item(
          res.title,
          new URL(res.link),
          res.encoded
        ))
        .forEach(item => observer.next(item));
      });
    });
  }

}
