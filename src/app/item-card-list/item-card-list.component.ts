import { Component, Input, OnChanges } from '@angular/core';

import { Item } from '../shared/models/item';
import { ItemStore } from '../shared/stores/item.store';
import { Person } from '../shared/models/person';

// TODO: 別のServiceに切り出す
import { SlideShareService } from '../slideshare.service';
import { MediumService } from '../medium.service';
import { HatenaService } from '../hatena.service';

import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/merge';
import 'rxjs/add/observable/timer';
import 'rxjs/add/observable/empty';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/expand';
import 'rxjs/add/operator/concatMap';

@Component({
  selector: 'app-item-card-list',
  templateUrl: './item-card-list.component.html',
  styleUrls: ['./item-card-list.component.sass']
})
export class ItemCardListComponent implements OnChanges {
  @Input() person: Person;
  items: Item[];
  constructor(
    public itemStore: ItemStore,
    public medium: MediumService,
    public hatena: HatenaService,
    public slideshare: SlideShareService
  ) {
    // ItemStoreの中で特定のpersonのものだけを保持する
    this.itemStore.list.subscribe(storedItems => {
      if (this.person) {
        this.items = storedItems.filter(item => {
          return item.personId === this.person.id;
        });
      }
    });
  }

  ngOnChanges() {
    // TODO: この処理を別のServiceに切り出す
    const polling = Observable.merge(
      this.hatena.fetchItems(this.person.name),
      this.slideshare.fetchItems(this.person.name),
      this.medium.fetchItems(this.person.name)
    );

    polling.expand(() => {
      return Observable.timer(30000).concatMap(() => polling);
    })
    .subscribe((fetchedItems: Item[]) => {
      fetchedItems.forEach(fetchedItem => {
        this.itemStore.list.subscribe(storedItems => {
          const fetchedUrl = fetchedItem.linkToContent.toString();
          const isAlreadyExists = storedItems
          .map(storedItem => {
            return storedItem.linkToContent.toString();
          })
          .some(storedUrl => storedUrl === fetchedUrl);
          if (!isAlreadyExists) {
            fetchedItem.personId = this.person.id;
            this.itemStore.insert(fetchedItem);
          }
        });
      });
    });
  }
}
