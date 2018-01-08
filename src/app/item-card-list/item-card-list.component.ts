import { Component, OnInit } from '@angular/core';

import { HatenaService } from '../hatena.service';
import { MediumService } from '../medium.service';
import { SlideShareService } from '../slideshare.service';
import { Observable } from 'rxjs';
import { TimerObservable } from 'rxjs/observable/TimerObservable';
import { Item } from '../../models/item';

@Component({
  selector: 'app-item-card-list',
  templateUrl: './item-card-list.component.html',
  styleUrls: ['./item-card-list.component.sass']
})
export class ItemCardListComponent implements OnInit {
  items: Item[];

  constructor(public medium: MediumService, public hatena: HatenaService, public slideshare: SlideShareService) {
  }

  ngOnInit() {
    // TimerObservable.create(0, 5000)
    // .subscribe(() => {
    //   Observable.merge(
    //     this.hatena.fetchItems(),
    //     this.medium.fetchItems(),
    //     this.slideshare.fetchItems()
    //   )
    //   .subscribe(items => {
    //     this.items = items.sort((item1, item2) => {
    //       return item2.created.getTime() - item1.created.getTime()
    //     });
    //   });
    // });
  }

}
