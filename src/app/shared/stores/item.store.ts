import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { TimerObservable } from 'rxjs/observable/TimerObservable';
import 'rxjs/add/observable/merge';

import { HatenaService } from '../../hatena.service';
import { MediumService } from '../../medium.service';
import { SlideShareService } from '../../slideshare.service';

import { AppStore } from '../../app.store';
import { Item } from '../models/item';

@Injectable()
export class ItemStore {

  get list(): Observable<Item[]> {
    return this.appStore.map(appStore => {
      return Object.keys(appStore.item).map(id => appStore.item[id])
        .filter((item: Item) => !!item)
        .sort((a: Item, b: Item) => b.created.getTime() - a.created.getTime());
    });
  }

  constructor(private appStore: AppStore) {}

  get(id: number): Observable<Item> {
    return this.appStore.map(appStore => appStore.item[id]);
  }

  insert(item: Item): void {
    const store = this.appStore.snapshot;
    item.id = Object.keys(store.item).length;
    store.item[item.id] = item;
    this.appStore.patchValue(store);
  }

  update(id: number, item: Item): void {
    const store = this.appStore.snapshot;
    store.item[item.id] = item;
    this.appStore.patchValue(store);
  }

  delete(id: number): void {
    const store = this.appStore.snapshot;
    store.item[id] = undefined;
    this.appStore.patchValue(store);
  }
}
