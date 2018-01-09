import { Component, Input, OnChanges } from '@angular/core';

import { Item } from '../../models/item';
import { ItemStore } from "../shared/stores/item.store";
import { Person } from '../../models/person';

// TODO: 別のServiceに切り出す
import { SlideShareService } from "../slideshare.service";
import { MediumService } from "../medium.service";
import { HatenaService } from "../hatena.service";

import { Observable } from 'rxjs/Observable';
import { TimerObservable } from 'rxjs/observable/TimerObservable';
import 'rxjs/add/observable/merge';

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
    itemStore.list.subscribe(storedItems => {
      this.items = storedItems.filter(item => {
        return item.personId === this.person.id;
      });
    });
  }

  ngOnChanges() {
    // TODO: User追加時にその場でやっていた、
    // Userに対応するItemを生成してStoreに突っ込む処理をやる
    // User に対応したitemの取得
    // YQLのリクエスト制限を超えないように

    console.log('fired');
    // TODO: この処理を別のServiceに切り出す
    this.itemStore.list.subscribe(storedItems => {
      TimerObservable.create(0, 5000).subscribe(() => {
        Observable.merge(
          this.hatena.fetchItems(this.person.name),
          this.medium.fetchItems(this.person.name),
          this.slideshare.fetchItems(this.person.name)
        ).subscribe(items => {
          items.forEach(item => {
            const itemUrl = item.linkToContent.toString();
            const isAlreadyExists = storedItems
              .map(storedItem => {
                return storedItem.linkToContent.toString();
              })
              .some(url => url === itemUrl);
            if (!isAlreadyExists) {
              item.personId = this.person.id;
              this.itemStore.insert(item);
              console.log('inserted: ', item);
            }   
          });
        });
      });
    });
  }
}
